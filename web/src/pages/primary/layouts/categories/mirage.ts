import Mirage from "../../../../lib/misc/mirage";
import { Category } from ".";

const Categories : Category[] = [
  { id: "1", label: "Loretta"},
  { id: "2", label: "Rosie"},
  { id: "3", label: "Brent"}
];

export const CategoryMirage = new Mirage({
  header: "SetupCategories",
  props: Categories
})
