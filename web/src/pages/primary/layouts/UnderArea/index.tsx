import { Transition } from '@headlessui/react';
import React, { ReactNode } from 'react';
import { usePrimary } from '../../context';

function UnderArea({ children }: { children: ReactNode }) {
  const { Visibility, Focus } = usePrimary();

  return (
    <Transition
      appear
      show={Visibility && Focus}
      as={React.Fragment}
      enter='ease-out duration-300'
      enterFrom='opacity-0 translate-y-[300px]'
      enterTo='opacity-100 translate-y-0'
      leave='ease-in duration-200'
      leaveFrom='opacity-100 translate-y-0'
      leaveTo='opacity-0 translate-y-[300px]'
    >
      <aside
        className='w-full h-80 '
        style={{
          position: 'absolute',
          bottom: 0
        }}
      >
        {children}
      </aside>
    </Transition>
  );
}

export default UnderArea;