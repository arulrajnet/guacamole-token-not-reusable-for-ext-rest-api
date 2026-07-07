package net.arulraj.demo;

import java.util.HashMap;
import java.util.Map;

import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.auth.AuthenticatedUser;
import org.apache.guacamole.net.auth.UserContext;
import org.apache.guacamole.net.auth.simple.SimpleUserContext;
import org.apache.guacamole.protocol.GuacamoleConfiguration;
import org.apache.guacamole.auth.header.HTTPHeaderAuthenticationProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Extended HTTP Header Authentication Provider with REST resource support.
 *
 * This provider extends HTTPHeaderAuthenticationProvider and exposes a REST API
 * via the getResource() method. The REST endpoints are accessible at:
 * - /guacamole/api/ext/header/hello
 * - /guacamole/api/ext/header/health
 */
public class DemoHTTPAuthProvider extends HTTPHeaderAuthenticationProvider {

  private static final Logger logger = LoggerFactory.getLogger(DemoHTTPAuthProvider.class);

  public DemoHTTPAuthProvider() throws GuacamoleException {
    super();
    logger.info("DemoHTTPAuthProvider initialized");
  }

  /**
   * Returns the REST resource for this authentication provider.
   *
   * The returned resource is exposed at: .../api/ext/header/
   * and is accessible by all users, regardless of authentication status.
   *
   * @return DemoRestResource instance with REST endpoints
   * @throws GuacamoleException if an error occurs
   */
  @Override
  public Object getResource() throws GuacamoleException {
    logger.info("getResource() called - returning DemoRestResource");
    return new DemoRestResource();
  }

  @Override
  public UserContext getUserContext(AuthenticatedUser authenticatedUser) throws GuacamoleException {
    logger.info("getUserContext() called - returning DemoUserContext");
    Map<String, GuacamoleConfiguration> attributes = new HashMap<>();
    GuacamoleConfiguration guacConfig = new GuacamoleConfiguration();
    attributes.put("default", guacConfig);
    return new DemoUserContext(this, attributes, getResource());
  }
}
