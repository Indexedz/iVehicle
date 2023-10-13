import React, { createContext, useContext, ReactNode } from 'react';
import useEvent from '../../lib/hooks/useEvent';
import { Category } from './layouts/categories';
import useEState from '../../lib/hooks/useEState';
import { Vehicle } from './layouts/shop';

interface PrimaryData {
  Category: string;
  Categories: Category[];
  setCategory: React.Dispatch<React.SetStateAction<string>>;

  Vehicle: string;
  Vehicles: Vehicle[];
  setVehicle: React.Dispatch<React.SetStateAction<string>>;

  Visibility: boolean;
  setVisibility: React.Dispatch<React.SetStateAction<boolean>>;

  Focus: boolean;
  setFocus: React.Dispatch<React.SetStateAction<boolean>>;

  Render: boolean;
  setRender: React.Dispatch<React.SetStateAction<boolean>>;
}

const PrimaryContext = createContext<PrimaryData | undefined>(undefined);

export function usePrimary() {
  const context = useContext(PrimaryContext);

  if (context === undefined) {
    throw new Error('PrimaryContext must be used within a PrimaryProvider');
  }

  return context;
}

interface PrimaryProviderProps {
  children: ReactNode;
}

export function PrimaryProvider({ children }: PrimaryProviderProps) {
  const [Category, setCategory] = React.useState<string>("");
  const [Vehicle, setVehicle] = React.useState<string>("");
  const [Visibility, setVisibility] = React.useState<boolean>(false);
  const [Render, setRender] = React.useState<boolean>(false);
  const [Focus, setFocus] = React.useState<boolean>(false);
  const [Categories] = useEState<Category[]>([], "SetupCategories");
  const [Vehicles] = useEState<Vehicle[]>([], "SetupVehicles");

  useEvent("setVisiblity", setVisibility)
  useEvent("setFocus", setFocus)
  useEvent("setDefaultCategory", setCategory)
  useEvent("setDefaultVehicle", setVehicle)

  const contextValue: PrimaryData = {
    Category, Categories, setCategory,
    Vehicle, Vehicles, setVehicle,
    Visibility, setVisibility,
    Focus, setFocus,
    Render, setRender
  };

  return (
    <PrimaryContext.Provider value={contextValue}>
      {children}
    </PrimaryContext.Provider>
  );
}

export default PrimaryContext;