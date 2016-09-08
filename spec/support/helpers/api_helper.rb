module ApiHelper
  include GrapeRouteHelpers::NamedRouteMatcher

  def json_response
    @_json_response ||= JSON.parse(response.body)
  end
end
