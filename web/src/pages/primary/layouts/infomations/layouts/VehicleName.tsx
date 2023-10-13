import { usePrimary } from "../../../context"

function VehicleName() {
  const { Vehicle, Vehicles } = usePrimary();
  const data = Vehicles.find(veh => veh.id == Vehicle)

  return (
    <>
      <div className="flex justify-between">
        <h1 className='uppercase font-bold'>{data?.label}</h1>
        <h3 className="text-green-300">{data?.price.toLocaleString()} $</h3>
      </div>
      <h2>{data?.brand}</h2>

      <hr className='my-2' />
    </>
  )
}

export default VehicleName