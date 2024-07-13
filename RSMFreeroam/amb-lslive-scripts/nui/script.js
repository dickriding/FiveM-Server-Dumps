window.addEventListener('message', (event) => 
{
  const data = event.data;
  if (data.type === 'openMenu')
  {
    let vp = document.getElementById("elevatorMenu");
    vp.style["display"] = 'block';
  }
  if (data.type === 'closeMenu')
  {
    let vp = document.getElementById("elevatorMenu");
    vp.style["display"] = 'none';
  }
})



function closeMenu()
{
    axios.post(`https://${GetParentResourceName()}/closeMenu`, {});
    
    let vp = document.getElementById("elevatorMenu");
    vp.style["display"] = 'none';
}

function openMenu()
{
  let vp = document.getElementById("elevatorMenu");
  vp.style["display"] = 'inline';
}

function selectFloor(floor) 
{
  // Replace this placeholder function with your logic to handle floor selection
  axios.post(`https://${GetParentResourceName()}/gotoFloor`, {floorId : floor});
  
}