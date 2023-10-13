import React from 'react';
import useEvent from './useEvent';

function useEState<T>(defaultValue: T, event: string): [
  state: T,
  setState: React.Dispatch<React.SetStateAction<T>>,
  isLoading: boolean,
  unload: () => void
] {
  const [state, setState] = React.useState<T>(defaultValue);
  const [isLoading, setLoading] = React.useState<boolean>(true);

  useEvent(event, (data: T) => {
    setState(data);
    setLoading(false);
  });

  const unload = () => {
    return setLoading(true);
  }

  return [state, setState, isLoading, unload]
}

export default useEState;
