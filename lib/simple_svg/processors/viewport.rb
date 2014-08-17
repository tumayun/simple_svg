module SimpleSvg
  module Processors
    module Viewport

      # 根据 target_height 缩放 width
      # 如: normalize_viewport([1024, 2048], 1024)
      # #=> [512, 1024]
      def normalize_viewport(viewport, target_height)
        width, height = viewport.map(&:to_f)
        target_height = target_height.to_f
        width  = target_height / height * width if height != target_height
        height = target_height

        [width, height]
      end
    end
  end
end
