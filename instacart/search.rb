require "json"
require "securerandom"
require "uri"
require_relative "client"

module Instacart
  class Search < Client

    def initialize(query)
      @query = query
    end

    def item_ids
      results = raw_search.dig("data", "searchResultsPlacements", "placements").map do |j|
        j.dig("content", "itemIds")
      end.compact.first

      return [] unless results

      results
    end

    private

    def raw_search
      CACHE.fetch("raw_search:#{@query}") do
        self.class.get search_url
      end
    end

    def search_url
      variables = {
        query: @query,
        shopId: Instacart::SHOP_ID,
        postalCode: Instacart::POSTAL_CODE,
        zoneId: Instacart::ZONE_ID,
        pageViewId: SecureRandom.uuid,
        first: 4
      }
      extensions = {
        persistedQuery: {
          version: 1,
          sha256Hash: "bc1d0bf4c510947cd08f43304bbc4bb3bb85d8dfcfaf4f06f230cb7e1a30adfd"
        }
      }
      params = URI.encode_www_form(
        operationName: "SearchResultsPlacements",
        variables: variables.to_json,
        extensions: extensions.to_json
      )
      "https://sameday.costco.com/graphql?#{params}"
    end
  end
end
