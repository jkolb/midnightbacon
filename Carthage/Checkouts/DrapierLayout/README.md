# DrapierLayout

#### Helps make layoutSubviews more readable

## Examples

#### A simple view with a UIImageView and two UILabels.

    class CustomView: UIView {
		var imageView: UIImageView!
		var titleLabel: UILabel!
		var detailLabel: UILabel!
		
		struct ViewLayout {
			let imageFrame: CGRect
			let titleFrame: CGRect
			let detailFrame: CGRect
		}
		
		func generateLayout(bounds: CGRect) -> ViewLayout {
			// Since a size is not specified, sizeThatFits is called on imageView with a 
			// size of 10,000 x 10,000 this allows the image to be as large as it can.
			var imageFrame = imageView.layout(
				Leading(equalTo: bounds.leading(layoutMargins)),
				Top(equalTo: bounds.top(layoutMargins))
			)
			
			let maximumImageWidth = CGFloat(50.0)
			
			if imageFrame.width > maximumImageWidth {
				// This time a size is specified, this attempts to make sure that the image
				// doesn't push the UILabels off the edge of the parent view.
				imageFrame = imageView.layout(
					Leading(equalTo: bounds.leading(layoutMargins)),
					Top(equalTo: bounds.top(layoutMargins)),
					Width(equalTo: maximumImageWidth),
					Height(equalTo: round(maximumImageWidth * imageFrame.inverseAspectRatio))
				)
			}
			
			// The title fits between the image and the trailing edge of the superview.
			// A capline is the line that marks the top of a capital letter for the 
			// UILabel's current font.
			let titleFrame = titleLabel.layout(
				Leading(equalTo: imageFrame.trailing, constant: 8.0),
				Trailing(equalTo: bounds.trailing(layoutMargins)),
				Capline(equalTo: imageFrame.top)
			)
			
			let detailFrame = detailLabel.layout(
				Leading(equalTo: titleFrame.leading),
				Trailing(equalTo: titleFrame.trailing),
				Capline(equalTo: titleFrame.baseline(font: titleLabel.font), constant: 8.0)
			)
			
			return ViewLayout(
				imageFrame: imageFrame,
				titleFrame: titleFrame,
				detailFrame: detailFrame
			)
		}
		
		override func sizeThatFits(size: CGSize) -> CGSize {
			let layout = generateLayout(size.rect())
			// Find the fitting height from the layout frame that is farthest toward the bottom, then
			// add in the layoutMargin bottom if needed to find the true height.
			let maxBottom = max(layout.imageFrame.bottom, layout.detailFrame.baseline(font: detailLabel.font))
			return CGSize(width: size.width, height: maxBottom + layoutMargins.bottom)
		}
		
		override func layoutSubviews() {
			super.layoutSubviews()
			
			// In most cases the layout code can be shared between sizeThatFits and layoutSubviews.
			let layout = generateLayout(bounds)
			
			imageView.frame = layout.imageFrame
			titleLabel.frame = layout.titleFrame
			detailLabel.frame = layout.detailFrame
		}
	}

## Contact

[Justin Kolb](mailto:justin.kolb@franticapparatus.net)  
[@nabobnick](https://twitter.com/nabobnick)

## License

DrapierLayout is available under the MIT license. See the LICENSE file for more info.
