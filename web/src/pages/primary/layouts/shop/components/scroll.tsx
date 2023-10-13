import React, { ReactNode } from 'react';

function VerticalScroll({ children, className }: { children: ReactNode, className: string }) {
  const scrollContainerRef = React.useRef<HTMLDivElement | null>(null);

  const handleScroll = (e: WheelEvent) => {
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollLeft += e.deltaY;
    }
  };

  React.useEffect(() => {
    const scrollContainer = scrollContainerRef.current;
    if (scrollContainer) {
      scrollContainer.addEventListener('wheel', handleScroll);
    }

    return () => {
      if (scrollContainer) {
        scrollContainer.removeEventListener('wheel', handleScroll);
      }
    };
  }, []);

  return (
    <div className={className} ref={scrollContainerRef} style={{
      overflowX: "scroll",
      overflowY: "hidden",
      width: "auto",
      height: "100%"
    }}>
      {children}
    </div>
  );
}

export default VerticalScroll;