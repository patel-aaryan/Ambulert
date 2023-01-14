async function getStuff() {
  const response = await fetch(
    "http://52.237.52.231/inrange?lat=347.54578&lon=46.646"
  );
  const json = await response.json();
  return json;
}

getStuff().then((data) => console.log(data));
