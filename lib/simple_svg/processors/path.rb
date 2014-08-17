module SimpleSvg
  module Processors
    module Path
      PARSABLE_ELEMENTS = %w(g path)

      def normalize_paths(svg_xml, transforms = [])
        path_data_and_transforms = []
        svg_xml.children.each do |node|
          if PARSABLE_ELEMENTS.include?(node.name)
            path_data_and_transforms += parse_node(node, transforms)
          end
        end

        path_data_and_transforms
      end

      private

      def parse_node(node, transforms)
        if node.name == 'g'
          send("parse_#{node.name}", node, transforms)
        else
          [send("parse_#{node.name}", node, transforms)]
        end
      end

      def parse_g(group, transforms = [])
        path_data_and_transforms = []
        group.children.each do |node|
          if PARSABLE_ELEMENTS.include?(node.name)
            path_data_and_transforms += parse_node(node, parse_transform(group['transform']) + transforms)
          end
        end

        path_data_and_transforms
      end

      def parse_path(path, transforms = [])
        data = path['d']
        return [] if data.blank?
        return [data, parse_transform(path['transform']) + transforms]
      end

      def parse_transform(transform)
        transforms = []
        if transform.present?
          transform.scan(/(?<command>translate|matrix|scale|rotate|skewX|skewY)\((?<args>.*?)\)/i).each do |(command, args)|
            transforms << [command, args.gsub(',', ' ').split(/\s+/).map(&:to_f)]
          end
        end

        transforms.reverse
      end
    end
  end
end
