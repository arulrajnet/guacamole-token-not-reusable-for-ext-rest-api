package net.arulraj.demo;

import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.auth.header.HTTPHeaderAuthenticationProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DemoHTTPAuthProvider extends HTTPHeaderAuthenticationProvider {

  private static final Logger logger = LoggerFactory.getLogger(DemoHTTPAuthProvider.class);

  public DemoHTTPAuthProvider() throws GuacamoleException {
    super();
    logger.info("DemoHTTPAuthProvider initialized");
  }
}
