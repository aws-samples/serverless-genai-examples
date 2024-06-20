export const handler = async (event) => {
    const { content, role } = event.Body;
    const { id, input: { appointmentType, carModel } } = event.Body.content[1];
    const messages = [];
    
    let tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    messages.push({
      role,
      content
    });
  
    messages.push({
      role: "user",
      content: [{
        "type": "tool_result",
        "tool_use_id": id,
        "content": [{
          type: "text", 
          "text": `Appointment for your ${carModel} has been set on ${tomorrow.toDateString()} for ${appointmentType} `
        }],
      }]
    });
    
    return messages;
  };
  