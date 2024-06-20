export const handler = async (event) => {
    console.log(event);
    const { content, role } = event.Body;
    const { id, input } = event.Body.content[1];
    const inventoryPresent = (input.carModel === '2015 Audi A7');
    const messages = [];
    
    messages.push({
      role,
      content
    });
    
    messages.push({
      role: "user",
      content: [{
        "type": "tool_result",
        "tool_use_id": id,
        "content": [{type: "text", "text": JSON.stringify({ inventoryPresent })}],
      }]
    });
  
    return messages;
  };
  