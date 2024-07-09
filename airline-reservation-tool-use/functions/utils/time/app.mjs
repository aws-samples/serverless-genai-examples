import moment from "moment";

export const lambdaHandler = async event => {
  const now = moment().format("dddd, MMMM Do YYYY, h:mm:ss a");
  return `Current date and time is ${now} UTC. ${event.input}`;
};