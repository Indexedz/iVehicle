import React from 'react';
import useEState from '../../../../../lib/hooks/useEState'
import { Stat, Grades, intialState } from '../typings'
import { usePrimary } from '../../../context'
import Loading from '../components/loading';

const format = (val: number) => {
  const split = 100 / Grades.length;

  const grade = Grades.find((_, index) => {
    const minRange = index * split;
    const maxRange = (index + 1) * split;
    return val >= minRange && val <= maxRange;
  });

  return <span>{grade || "ไม่ทราบ"}</span>;
};

function VehicleStats({ children }: { children: React.ReactNode }) {
  const [Stats, , isLoading, unload] = useEState<Stat[]>(intialState, "initStats");
  const { Vehicle } = usePrimary();

  React.useEffect(unload, [Vehicle])

  return (
    <section >
      {!isLoading ? (
        Stats.map((Stat) => {
          return (
            <div key={Stat.id} className='flex justify-between'>
              <div className='uppercase'>{Stat.label} : </div>
              <div className='text-right' >
                {
                  !Stat.format ? (
                    (Stat.value).toFixed(Stat.fixed)
                  ) : (
                    format(Stat.value)
                  )
                }
                {
                  Stat.weight ? (` - ${(Stat.weight / 1000).toFixed()} kg`) : (null)
                }
              </div>
            </div>
          )
        })

      ) : (<Loading />)}

      {!isLoading ? children : null}
    </section>
  )
}

export default VehicleStats