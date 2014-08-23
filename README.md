simple_svg
==========

将复杂 svg 转换为相对简单的 svg，转换前后的 svg 图像完全一致！

## Usage

```ruby
  parser = SimpleSvg.Parser.new('/User/tumayun/Documents/test.svg', 1024)
  parser.to_simple_svg
```

### 转换之前的 svg 内容

    <?xml version="1.0" encoding="utf-8"?>
    <!-- Generator: Adobe Illustrator 16.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg version="1.1" id="图层_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0" y="0"
    	 width="1024" height="1024" viewBox="0, 0, 1024, 1024" enable-background="new 0 0 10 10" xml:space="preserve">
    <g transform="scale(16 16)">
    <path d="M45.959,51H18c-0.28,0-0.547-0.117-0.737-0.324c-0.189-0.206-0.284-0.482-0.259-0.762l2.32-27
    	C19.368,22.397,19.8,22,20.319,22h23.733c0.525,0,0.961,0.406,0.997,0.93l1.906,27c0.02,0.276-0.076,0.549-0.266,0.752
    	S46.236,51,45.959,51z M19.089,49h25.796l-1.765-25H21.237L19.089,49z"/>
    <g>
    	<defs>
    		<rect id="SVGID_1_" width="64" height="64"/>
    	</defs>
    	<clipPath id="SVGID_2_">
    		<use xlink:href="#SVGID_1_"  overflow="visible"/>
    	</clipPath>
    	<path clip-path="url(#SVGID_2_)" d="M40.286,20.172h-2c0-4.721-4.438-5.755-6.148-5.755s-6.148,1.034-6.148,5.755h-2
    		c0-5.69,4.873-7.755,8.148-7.755S40.286,14.482,40.286,20.172z"/>
    	<path clip-path="url(#SVGID_2_)" d="M22.872,26.86c0-1.199,0.972-2.171,2.171-2.171c1.199,0,2.171,0.972,2.171,2.171
    		c0,1.199-0.972,2.171-2.171,2.171C23.844,29.031,22.872,28.059,22.872,26.86"/>
    	<path clip-path="url(#SVGID_2_)" d="M36.851,26.86c0-1.199,0.973-2.171,2.171-2.171c1.199,0,2.171,0.972,2.171,2.171
    		c0,1.199-0.972,2.171-2.171,2.171C37.823,29.031,36.851,28.059,36.851,26.86"/>
    </g>
    </g>
    </svg>

### 转换后的 svg 内容

    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0" y="0" width="1024.0" height="1024.0" viewBox="0 0 1024.0 1024.0" enable-background="new 0 0 1024.0 1024.0" xml:space="preserve">
      <path d="M735.344 816 288 816c-4.48 0-8.752-1.872-11.792-5.184-3.024-3.296-4.544-7.712-4.144-12.192l37.12-432C309.888 358.352 316.8 352 325.104 352l379.728 0c8.4 0 15.376 6.496 15.952 14.88l30.496 432c0.32 4.416-1.216 8.784-4.256 12.032S739.776 816 735.344 816zM305.424 784l412.736 0-28.24-400L339.792 384 305.424 784zM644.576 322.752l-32 0c0-75.536-71.008-92.08-98.368-92.08s-98.368 16.544-98.368 92.08l-32 0c0-91.04 77.968-124.08 130.368-124.08S644.576 231.712 644.576 322.752zM365.952 429.76c0-19.184 15.552-34.736 34.736-34.736 19.184 0 34.736 15.552 34.736 34.736 0 19.184-15.552 34.736-34.736 34.736C381.504 464.496 365.952 448.944 365.952 429.76M589.616 429.76c0-19.184 15.568-34.736 34.736-34.736 19.184 0 34.736 15.552 34.736 34.736 0 19.184-15.552 34.736-34.736 34.736C605.168 464.496 589.616 448.944 589.616 429.76"/>
    </svg>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Reques
