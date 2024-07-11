export const lambdaHandler = async (event, context) => {
  // Sample code that returns static value for customers including firstname, lastname, homeAirport code
  return {
    'statusCode': 200,
    'body': JSON.stringify({
      'id': 1234,
      'firstname': 'John',
      'lastname': 'Doe',
      'homeAirport': 'KJFK'
    })
  }
};
