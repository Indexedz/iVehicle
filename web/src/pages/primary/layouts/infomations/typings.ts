export type StatName = "acceleration" | "speed" | "handler" | "braking" | "seats" | "capacity" | "gears" | 'glovebox' | "trunk"
export interface Stat {
  id: StatName,
  label: string,
  value: number ,
  fixed?: number,
  format?: "grade",
  weight?: number
}

export const Grades = ["แย่", "ปกติ", "ดี", "ดีมาก"]
export const intialState: Stat[] = [
  { id: "speed", label: "speed", value: 0},
  { id: "acceleration", label: "acceleration", value: 20, format: "grade" },
  { id: "handler", label: "handler", value: 0, format: "grade" },
  { id: "braking", label: "braking", value: 0, format: "grade" }
]