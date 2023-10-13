import React from 'react'
import useFetch from '../../../../../lib/hooks/useFetch';

interface Colour {
  id: string;
  name: string;
}
const Colours: Colour[] = [
  { id: '1', name: 'black' },
  { id: '27', name: 'darkred' },
  { id: '135', name: 'deeppink' },
  { id: '99', name: 'saddlebrown' },
  { id: '64', name: 'Blue' },
  { id: '128', name: 'darkolivegreen' },
  { id: '38', name: 'orange' },
  { id: '107', name: 'khaki' }
]

function VehicleColours() {
  const [Colored, setColored] = React.useState<string>("1");

  const onChange= (colorId : string) => {
    setColored(colorId);
    useFetch("ChangeColored", colorId)
  }

  return (
    <div className='text-center my-2'>
      <ul className='inline-flex space-x-1'>
        {
          Colours.map((color) => {
            return (
              <li
                key={color.id}
                onClick={() => onChange(color.id)}
                className={`h-6 w-6 rounded transition-all cursor-pointer hover:rotate-12 active:rotate-90 bg-white ${Colored == color.id ? (
                  `ring-2 ring-gray-200 rounded-full scale-100  ms-2`
                ): (
                  `ring-0 scale-75`
                )}`}
                style={{
                  backgroundColor: color.name
                }}
              />
            )
          })
        }
      </ul>
    </div>
  )
}

export default VehicleColours