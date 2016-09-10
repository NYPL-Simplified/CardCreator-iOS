enum AddressStep {
  case Home
  case School(homeAddress: Address)
  case Work(homeAddress: Address)
}