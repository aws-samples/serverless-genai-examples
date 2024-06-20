export const handler = async (event) => {
  const { input: { carModel } } = event;
  const targetModel = '2015 Audi A7';

  return {
    inventoryPresent: carModel === targetModel
  };
};