module SimpleSvg
  module Processors
    module ViewBox

      # 将 viewbox 转换成 target_view_box
      def normalize_view_box(view_box, target_view_box)
        transforms = []
        transforms += normalize_x_and_y(view_box, target_view_box)
        transforms += normalize_width_and_height(view_box, target_view_box)
        transforms
      end

      private

      def normalize_x_and_y(view_box, target_view_box)
        x, y = view_box[0..1].map(&:to_f)
        target_x, target_y = target_view_box[0..1].map(&:to_f)
        if x != target_x || y != target_y
          [['translate', [target_x - x, target_y - y]]]
        else
          []
        end
      end

      def normalize_width_and_height(view_box, target_view_box)
        width, height = view_box[2..3].map(&:to_f)
        target_width, target_height = target_view_box[2..3].map(&:to_f)
        width_scale  = width / target_width
        height_scale = height / target_height
        return [['scale', [1 / width_scale, 1 / width_scale]]] if width_scale == height_scale

        scale = [width_scale, height_scale].max
        transforms = []
        if width_scale < height_scale
          new_width  = target_width * scale
          transforms << ['translate', [(new_width - width) / 2, 0]]
        elsif width_scale > height_scale
          new_height = target_height * scale
          transforms << ['translate', [0, (new_height - height) / 2]]
        end

        transforms << ['scale', [1 / scale, 1 / scale]]

        transforms
      end
    end
  end
end
