require_relative "test_helper"

class AssetsTest < ActionDispatch::IntegrationTest
  def test_javascript
    get blazer.asset_file_path("moment.js")
    assert_response :success
    assert_match(/javascript/, content_type)
    assert response.body.size > 0
  end

  def test_stylesheet
    get blazer.asset_file_path("application.css")
    assert_response :success
    assert_equal "text/css", content_type
    assert response.body.size > 0
  end

  def test_nested_asset
    get blazer.asset_file_path("ace/ace.js")
    assert_response :success
    assert_match(/javascript/, content_type)
  end

  def test_font
    get blazer.asset_file_path("glyphicons-halflings-regular.woff2")
    assert_response :success
    assert response.body.size > 0
  end

  def test_favicon
    get blazer.asset_file_path("favicon.png")
    assert_response :success
    assert_equal "image/png", content_type
  end

  def test_missing_asset
    get blazer.asset_file_path("does-not-exist.js")
    assert_response :not_found
  end

  def test_path_traversal_rejected
    get "/blazer-assets/../../../Gemfile"
    assert_response :not_found
  end

  def test_layout_references_engine_assets
    get blazer.root_path
    assert_response :success
    assert_match %r{blazer-assets/moment\.js}, response.body
    assert_match %r{blazer-assets/application\.css}, response.body
    assert_no_match %r{/assets/blazer}, response.body
  end

  private

  def content_type
    response.media_type
  end
end
