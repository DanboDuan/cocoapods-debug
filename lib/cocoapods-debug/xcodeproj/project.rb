require 'xcodeproj'

module Xcodeproj
  class Project

    def debug_dev_pods
      return groups.select { |e| e.name == "Development Pods" }.map { |e|
        e.children.map { |x| x.to_s  } 
      }.flatten.uniq
    end

    def debug_dependency_pods
      return groups.select { |e| e.name == "Pods" }.map { |e|
        e.children.map { |x| x.to_s  } 
      }.flatten.uniq
    end

  end
end