# Fixes https://github.com/ruby-grape/grape/issues/1174
# Stolen from https://github.com/hassox/warden/pull/119
# TODO: remove below once the fix merged and released (hopefully)
require 'warden/manager'

module Warden
  class Manager
    def call(env) # :nodoc:
      return @app.call(env) if env['warden'] && env['warden'].manager != self

      env['warden'] = Proxy.new(env, self)
      result = catch(:warden) do
        @app.call(env)
      end

      result ||= {}
      case result
      when Array
        handle_chain_result(result.first, result, env)
      when Hash
        process_unauthenticated(env, result)
      when Rack::Response
        handle_chain_result(result.status, result, env)
      end
    end

  private

    def handle_chain_result(status, result, env)
      if status == 401 && intercept_401?(env)
        process_unauthenticated(env)
      else
        result
      end
    end
  end
end
