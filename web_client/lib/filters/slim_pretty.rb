# encoding: utf-8
module Nanoc::Filters
  class SlimPretty < Slim
    def run(content, params={})
      super(content, pretty: true)
    end
  end
end
