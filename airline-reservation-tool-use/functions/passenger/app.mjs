export const lambdaHandler = async (event, context) => {
  // for a particular customer id, return static data with an array of passengers related to this owner with their firstname, lastname, homeAirport
  return {
    'statusCode': 200,
    'body': JSON.stringify({
      'ownerId': 1234,
      'passengers': [
        {
          'firstname': 'Jill',
          'lastname': 'Doe',
          'homeAirport': 'KJFK',
          'ownerRelationship': 'Wife',
          'age': '39'
        },
        {
          'firstname': 'Jane',
          'lastname': 'Doe',
          'homeAirport': 'KORD',
          'ownerRelationship': 'Daughter',
          'age': '20'
        },
        {
          'firstname': 'Jenny',
          'lastname': 'Doe',
          'homeAirport': 'KCMH',
          'ownerRelationship': 'Daughter',
          'age': '24'
        }
      ]
    })
  }
};
