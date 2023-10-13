import React from 'react';
import useFetch from '../../../../lib/hooks/useFetch';
import { Transition } from '@headlessui/react';
import { usePrimary } from '../../context';

/* Layouts */
import VehicleStats from "./layouts/VehicleStats"
import VehicleName from "./layouts/VehicleName"
import VehicleColours from './layouts/VehicleColours';

/* Components */
import Confirmation from './components/confirmation';

function Information() {
  const [isConfirmation, setConfirmation] = React.useState<boolean>(false);
  const { Visibility, Vehicle, Vehicles, setVisibility } = usePrimary();

  const veh = Vehicles.find(veh => veh.id == Vehicle);

  const onConfirm = (statement: string) => {
    setVisibility(false);
    useFetch("BuyVehicle", {
      id: Vehicle,
      statement: statement
    })
  }

  return (
    <>
      <Confirmation
        isOpen={isConfirmation}
        setOpen={setConfirmation}
        title="แจ้งเตือน"
        text={`คุณต้องการซื้อ ${veh?.brand} | ${veh?.label} ในราคา ${veh?.price.toLocaleString()} $ หรือไม่ ?`}
        onConfirm={onConfirm}
      />
      <Transition
        appear
        show={Visibility}
        as={React.Fragment}
        enter='ease-out duration-300'
        enterFrom='opacity-0 translate-x-[-300px]'
        enterTo='opacity-100 translate-x-0'
        leave='ease-in duration-200'
        leaveFrom='opacity-100 translate-x-0'
        leaveTo='opacity-0 translate-x-[-300px]'
      >
        <div
          className='w-72 p-5 text-white'
          style={{
            position: 'absolute',
            top: 50,
            left: 30
          }}
        >
          <VehicleName />
          <VehicleColours />
          <VehicleStats >
            <hr className='my-4' />
            <button onClick={() => setConfirmation(true)} className='w-full active:text-gray-300 transition-all'>BUY</button>
          </VehicleStats >
        </div>
      </Transition>
    </>
  )
}

export default Information