export const handler = async (event) => {
  const { appointmentType, carModel } = event.input;

  let tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  return {
    "appointment": `Appointment for your ${carModel} has been set on ${tomorrow.toDateString()} for ${appointmentType}`
  };
};
