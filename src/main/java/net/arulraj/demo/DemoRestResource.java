package net.arulraj.demo;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Simple REST resource exposed by the DemoHTTPAuthProvider extension.
 * This resource is accessible at: /guacamole/api/ext/header/
 */
@Path("/")
@Produces(MediaType.APPLICATION_JSON)
public class DemoRestResource {

  private static final Logger logger = LoggerFactory.getLogger(DemoRestResource.class);

  /**
   * Simple hello endpoint to verify the REST resource is working.
   * Accessible at: GET /guacamole/api/ext/header/hello
   *
   * @return A simple JSON response
   */
  @GET
  @Path("hello")
  public String hello() {
    logger.info("Hello endpoint invoked");
    return "{\"message\": \"Hello from DemoHTTPAuthProvider!\", \"status\": \"success\"}";
  }

  /**
   * Health check endpoint.
   * Accessible at: GET /guacamole/api/ext/header/health
   *
   * @return Health status as JSON
   */
  @GET
  @Path("health")
  public String health() {
    logger.info("Health check endpoint invoked");
    return "{\"status\": \"healthy\", \"provider\": \"DemoHTTPAuthProvider\"}";
  }
}
