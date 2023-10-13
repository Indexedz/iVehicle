import React from 'react'
import ReactDOM from 'react-dom/client'
import NavigationProvider from './lib/navigation/provider'
import Route from './lib/navigation/route'
import './global.css'

/* PAGES */
import Primary from './pages/primary'
import isEnvBrowser from './lib/misc/browser'

if (isEnvBrowser()) {
  const root = document.getElementById('root');

  // https://i.imgur.com/iPTAdYV.png - Night time img
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <NavigationProvider default="primary">
      <Route name="primary" element={<Primary />} />
    </NavigationProvider>
  </React.StrictMode>,
)