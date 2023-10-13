import { SetupVehicles } from './mirage';
import { usePrimary } from '../../context';
import VerticalScroll from './components/scroll';
import useFetch from '../../../../lib/hooks/useFetch';

export interface Vehicle {
  id: string,
  category: string,
  label: string,
  brand: string,
  model: string,
  price: number
}

SetupVehicles.mirage()

function Shop() {
  const {
    Category,
    Render,
    setRender,
    Vehicles: vehicles,
    Vehicle: select,
    setVehicle,
  } = usePrimary();

  const onChange = (vehId: string) => {
    if (select == vehId) return
    if (Render) return

    setRender(true)
    setVehicle(vehId)
    useFetch("ChangeVehicle", vehId, true).then(() => setRender(false))
  }


  return (
    <div className='grow w-full p-2 bg-black bg-opacity-70 text-center'>
      <VerticalScroll className='h-full overflow-x-scroll flex'>
        {
          vehicles
            .filter(veh => veh.category == Category)
            .sort((a, b) => a.price - b.price)
            .map(veh => {
              return (
                <div
                  className={
                    `transition-all cursor-pointer w-60 h-full rounded ${select == veh.id ?
                      'bg-gray-200 scale-100' :
                      'bg-gray-400 scale-90'}`
                  }
                  onClick={() => onChange(veh.id)}
                  key={veh.id}
                  style={{ flex: '0 0 auto' }}
                >
                  <div
                    className='w-full flex justify-between center p-1 px-2'
                  >
                    <span className='text-emerald-700 font-bold'>
                      {veh.price.toLocaleString()} $
                    </span>
                  </div>
                  <div
                    className='pointer-events-none'
                    style={{
                      position: 'absolute',
                      left: '50%',
                      top: '50%',
                      transform: 'translate(-50%, -50%)'
                    }}
                  >
                    <ul>
                      <li>{veh.label}</li>
                      <li className='font-bold'>{veh.brand}</li>
                    </ul>
                  </div>
                </div>
              )
            })
        }
      </VerticalScroll>
    </div>
  )

}

export default Shop