require_relative 'processors/path'
require_relative 'processors/view_box'
require_relative 'processors/viewport'
module SimpleSvg
  class Parser
    include SimpleSvg::Processors::Path
    include SimpleSvg::Processors::ViewBox
    include SimpleSvg::Processors::Viewport
    attr_accessor :file_path, :target_height, :perfect

    ## file_path:
    #    svg file path
    #
    ## target_height:
    #    期望 svg viewport 高度最终转换为 target_height
    #
    ## 严格模式:
    #     只将复杂 svg 转换为简单 svg。
    #     假设传入的 target_height 值为 1024，
    #     最终生成的 svg viewport height 应该是 1024， viewport width 根据 height 等比缩放，
    #     得出的 view_box 为 (0, 0, viewport_width, viewport_height)，path 会进行重新计算,
    #     得出调整后的 path，但是生成的新 svg 图像与原始的 svg 图像完全一致！
    #
    #     如原始 viewport 为 (1024, 512)，view_box 为 (-100, -100, 1000, 2000)，传入的 target_height 为 1024，
    #     生成的新 svg viewport 为 (2048, 1024)，view_box 为 (0, 0, 2048, 1024)。
    #     同时 path 计算后， 最终得出的 svg 图像与原始图像完全一致！
    #
    ## 完美模式:
    #     先进行严格模式，得出转换后的简单 svg，然后进一系列转换。
    #     假设传入的 target_height 值为 1024，
    #     如果得出的简单 svg viewport width 小于 1024，要两边补宽到 1024。
    #     如果由于 viewport width 原因导致 svg 展示不全，补宽至能完全展示。
    #     如果由于 viewport height 原因导致 svg 展示不全，缩小至能完全展示。
    #
    ## perfect:
    #    true 则开启完美模式
    #    false 启用严格模式
    def initialize(file_path, target_height, perfect = false)
      @file_path     = file_path
      @target_height = target_height
      @perfect       = !!perfect
      @svg_xml       = Nokogiri::XML(SvgPathify.convert(File.read(file_path)), &:noblanks).css('svg').first
      @bounding_box  = self.class.get_bounding_box(file_path)
      @_viewport     = get_viewport
      @_view_box     = get_view_box
      @_unperfect_viewport = normalize_viewport(@_viewport, @target_height)
      perfect_it! if @perfect
    end

    def file_path=(file_path)
      @file_path    = file_path
      @svg_xml      = Nokogiri::XML(SvgPathify.convert(File.read(file_path)), &:noblanks).css('svg').first
      @bounding_box = self.class.get_bounding_box(file_path)
      @_viewport    = get_viewport
      @_view_box    = get_view_box
      @_unperfect_viewport = normalize_viewport(@_viewport, @target_height)
      perfect_it! if @perfect
    end

    def target_height=(target_height)
      @target_height = target_height
      @_unperfect_viewport = normalize_viewport(@_viewport, @target_height)
      perfect_it! if @perfect
    end

    def perfect=(perfect)
      @perfect = !!perfect
      perfect_it! if @perfect
    end

    def self.get_bounding_box(file_path)
      `inkscape -S "#{file_path}"`.to_s.split("\n").first.to_s.split(',')[1..4].map(&:to_f) rescue [0.0] * 4
    end

    def viewport
      @perfect ? @_perfect_viewport : @_unperfect_viewport
    end

    def view_box
      [0, 0, *viewport]
    end

    def to_simple_paths
      simple_paths = []
      transforms   = normalize_view_box(@_view_box, [0, 0, *@_unperfect_viewport])
      transforms  += @_perfect_transforms if @perfect
      normalize_paths(@svg_xml, transforms).each do |(path, transform)|
        parser = Savage::Parser.parse path
        transform.each do |(command, args)|
          parser.send(normalize_command(command), *args)
        end
        simple_paths << parser.to_command
      end

      simple_paths
    end

    def to_simple_svg
      <<-SVG
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0" y="0" width="#{viewport[0]}" height="#{viewport[1]}" viewBox="#{view_box.join(' ')}" enable-background="new #{view_box.join(' ')}" xml:space="preserve">
  <path d="#{to_simple_paths.join}"/>
</svg>
      SVG
    end

    private

    def normalize_command(command)
      case command.downcase
      when 'matrix'
        'transform'
      when 'skewX'
        'skew_x'
      when 'skewY'
        'skew_y'
      else
        command
      end
    end

    def get_view_box
      viewbox = @svg_xml.attr('viewBox').to_s.gsub(',', ' ').split(' ').map(&:to_f)
      return viewbox if viewbox.size == 4

      width, height = @svg_xml.attr('width').to_f, @svg_xml.attr('height').to_f
      return [0, 0, width, height] if width != 0 && height != 0

      [0, 0, *@bounding_box[2..3]]
    end

    def get_viewport
      width, height = @svg_xml.attr('width').to_f, @svg_xml.attr('height').to_f
      return [width, height] if width != 0 && height != 0

      viewbox = @svg_xml.attr('viewBox').to_s.gsub(',', ' ').split(' ').map(&:to_f)
      return @bounding_box[2..3] if viewbox.size != 4

      width  = viewbox[2] if width  == 0
      height = viewbox[3] if height == 0
      [width, height]
    end

    def perfect_it!
      scale = @_unperfect_viewport[1] / @_viewport[1]
      @bounding_box.map! { |v| v * scale }
      @_perfect_transforms = []
      @_perfect_viewport = [*@_unperfect_viewport]
      perfect_height!
      perfect_width!
    end

    # 处理 svg 因为宽度被遮挡的情况
    def perfect_width!
      width = @_perfect_viewport[0]
      if @bounding_box[0] + @bounding_box[2] > width
        if @bounding_box[0] >= 0
          offset = @bounding_box[0] + @bounding_box[2] - width
        else
          left_offset  = @bounding_box[0].abs
          right_offset = @bounding_box[0] + @bounding_box[2] - width
          offset = [left_offset, right_offset].max
        end
        @_perfect_transforms << ['translate', [offset, 0]]
        width += 2 * offset
      elsif @bounding_box[0] < 0
        offset = -@bounding_box[0]
        @_perfect_transforms << ['translate', [offset, 0]]
        width += 2 * offset
      end

      # 宽度不够
      if width < @target_height
        @_perfect_transforms << ['translate', [(@target_height - width) / 2.0, 0]]
        width = @target_height
      end

      @_perfect_viewport[0] = width
    end

    # 处理 svg 因为高度被遮挡的情况
    def perfect_height!
      height = @_perfect_viewport[1]
      if @bounding_box[1] + @bounding_box[3] > height
        if @bounding_box[1] >= 0
          offset = @bounding_box[1] + @bounding_box[3] - height
        else
          top_offset    = @bounding_box[1].abs
          bottom_offset = @bounding_box[1] + @bounding_box[3] - height
          offset = [top_offset, bottom_offset].max
        end
        @_perfect_transforms << ['translate', [0, offset]]
        height += 2 * offset
      elsif @bounding_box[1] < 0
        offset = -@bounding_box[1]
        @_perfect_transforms << ['translate', [0, offset]]
        height += 2 * offset
      end

      # height 与 @target_height 不相等, 等比压缩
      if height != @target_height
        scale = @target_height.to_f / height
        @_perfect_transforms << ['scale', [scale, scale]]
        @_perfect_viewport[0] *= scale
        @bounding_box.map! { |v| v * scale }
        height = @target_height
      end

      @_perfect_viewport[1] = height
    end
  end
end
