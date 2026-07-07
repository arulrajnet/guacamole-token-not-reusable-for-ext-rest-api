package net.arulraj.demo;

import org.apache.guacamole.net.auth.simple.SimpleUserContext;
import org.apache.guacamole.net.auth.AuthenticationProvider;
import org.apache.guacamole.protocol.GuacamoleConfiguration;
import org.apache.guacamole.GuacamoleException;
import java.util.Map;

public class DemoUserContext extends SimpleUserContext {

    private final Object myResource;

    public DemoUserContext(AuthenticationProvider authProvider,
                           Map<String, GuacamoleConfiguration> configs,
                           Object myResource) {
        super(authProvider, configs);
        this.myResource = myResource;
    }

    @Override
    public Object getResource() throws GuacamoleException {
        // This links your REST resource directly to /api/session/ext/demo-auth/
        return myResource;
    }
}
