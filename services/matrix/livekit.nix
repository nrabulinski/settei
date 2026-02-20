{
  services.livekit = {
    # enable = true;
  };

  services.lk-jwt-service = {
    # enable = true;
    port = 6169;
    keyFile = "TODO";
    livekitUrl = "wss://livekit.rab.lol";
  };
}
