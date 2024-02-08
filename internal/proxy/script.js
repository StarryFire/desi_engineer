let src = new EventSource("/proxy/events");
src.onmessage = (event) => {
  // console.log("received event", event);
  if (event && event.data === "reload") {
    window.location.reload();
  }
};
src.onopen = () => {
  // console.log("connected to proxy server");
};
