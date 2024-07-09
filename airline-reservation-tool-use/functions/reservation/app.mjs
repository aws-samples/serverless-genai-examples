export const lambdaHandler = async event => {
  console.log(event);

  // Create a reservation using the incoming payload from the event.
  const reservation = await createReservation(event);

  // Return the reservation to the caller.
  return {
    'statusCode': 200,
    'body': JSON.stringify(reservation)
  }
};

const createReservation = async event => {
  // Extract the data from the event.
  const { 
    firstname, 
    lastname, 
    date, 
    from,
    to,
    passengers 
  } = event.input;

  // Create a new reservation.
  const reservation = {
    firstname,
    lastname,
    date,
    from, 
    to,
    passengers
  };

  // Return the reservation.
  return reservation;
};