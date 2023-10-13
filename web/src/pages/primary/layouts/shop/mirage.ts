import Mirage from "../../../../lib/misc/mirage";
import { Vehicle } from ".";

const Vehicles: Vehicle[] = [];

export const SetupVehicles = new Mirage({
  header: "SetupVehicles",
  props: Vehicles
})