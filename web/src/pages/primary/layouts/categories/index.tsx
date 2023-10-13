import { CategoryMirage } from './mirage';
import { usePrimary } from '../../context';

export interface Category {
  id: string,
  label: string
}

CategoryMirage.mirage();

function Categories() {
  const {
    Category: select,
    Categories: categories,
    setCategory,
    Render
  } = usePrimary();

  const onChange = (id: string) => {
    if (select == id) {
      return
    }

    if (Render) {
      return
    }

    setCategory(id);
  }

  return (
    <div className='text-center py-3 bg-tranparency '>
      <ul className='inline-flex  '>
        {
          categories.map((category) => {
            return (
              <li
                onClick={() => onChange(category.id)}
                className={`bg-black px-5 pb-1 transition-all rounded bg-opacity-50 cursor-pointer ${select == category.id ? 'text-white scale-100' : 'text-gray-400 scale-75'}`}
                key={category.id}
              >
                {category.label}
              </li>
            )
          })
        }
      </ul>
    </div>
  )
}

export default Categories