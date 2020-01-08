unless defined? Rails
  require File.expand_path("../../config/environment", __FILE__)
end

class ModelRowsCollector < G5devops::ModelRowsCollector
  @@model_classes = []
end
