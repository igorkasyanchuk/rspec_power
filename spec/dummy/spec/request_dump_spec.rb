require_relative "./rails_helper"

RSpec.describe "Dump helpers", type: :request do
  it "dumps selected items via :with_request_dump", with_request_dump: { what: [ :session, :cookies, :flash, :headers ] } do
    post "/set_state"
    expect(response).to have_http_status(:ok)
  end

  it "dumps session only via :with_request_dump", with_request_dump: { what: [ :session ] } do
    post "/set_state"
    expect(response).to have_http_status(:ok)
  end
end
