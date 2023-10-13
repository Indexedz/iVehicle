/* CONTEXT */
import { PrimaryProvider } from './context';

/* LAYOUYS */
import Information from './layouts/infomations';
import UnderArea from './layouts/UnderArea';
import Categories from './layouts/categories';
import Shop from './layouts/shop';
import Toolbar from './layouts/toolbar';

function Primary() {
  return (
    <PrimaryProvider>
      <Information />
      <UnderArea>
        <Toolbar />
        <section className='absolute bottom-0 h-2/3 w-full flex flex-col'>
          <Categories />
          <Shop />
        </section>
      </UnderArea>
    </PrimaryProvider>
  )
}

export default Primary