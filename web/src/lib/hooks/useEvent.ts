import React from "react"

export interface Event<T = unknown> {
  isMultiple?: boolean,
  header: string,
  props: T
}

export default function useEvent<T = any>(header: string, cb: (props: T) => void) {
  const callback: React.MutableRefObject<(props: T) => void> = React.useRef(() => { })

  React.useEffect(() => {
    callback.current = cb
  }, [cb])

  React.useEffect(() => {
    const event = (event: MessageEvent<Event<T>>) => {
      const payload = event.data

      const usePayload = (payload: Event) => {
        if (header != payload.header) {
          return
        }

        callback.current(payload.props as T)
      }

      if (payload?.isMultiple) {
        return (payload.props as Event[]).map(usePayload)
      }

      return usePayload(payload)
    }

    window.addEventListener("message", event)
    return () => window.removeEventListener("message", event)
  }, [header])
}