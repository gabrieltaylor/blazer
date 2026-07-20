module Blazer
  # Serves Blazer's bundled JS/CSS/fonts directly from the engine so Blazer
  # works without a host asset pipeline (no Sprockets, Propshaft, or importmap).
  class AssetsController < ActionController::Base
    # Public, GET-only static files. Skip CSRF and the cross-origin JavaScript
    # check so the vendored JS can be embedded via plain <script> tags.
    self.allow_forgery_protection = false
    skip_forgery_protection
    skip_after_action :verify_same_origin_request, raise: false

    ASSET_ROOTS = [
      Blazer::Engine.root.join("app", "assets", "javascripts", "blazer"),
      Blazer::Engine.root.join("app", "assets", "stylesheets", "blazer"),
      Blazer::Engine.root.join("app", "assets", "fonts", "blazer"),
      Blazer::Engine.root.join("app", "assets", "images", "blazer")
    ].map { |path| File.expand_path(path.to_s) }.freeze

    def show
      file = resolve(params[:path].to_s)

      if file
        expires_in 1.year, public: true
        send_file file, type: content_type_for(file), disposition: "inline"
      else
        head :not_found
      end
    end

    private

    # Resolve a request path to a real file inside one of the asset roots.
    # Rejects path traversal and only serves files that actually exist.
    def resolve(path)
      return nil if path.empty? || path.include?("..") || path.include?("\0")

      ASSET_ROOTS.each do |root|
        candidate = File.expand_path(File.join(root, path))
        return candidate if candidate.start_with?(root + File::SEPARATOR) && File.file?(candidate)
      end

      nil
    end

    def content_type_for(file)
      Rack::Mime.mime_type(File.extname(file), "application/octet-stream")
    end
  end
end
