// The MIT License (MIT)
//
// Copyright (c) 2015-2021 Alexander Grebenyuk (github.com/kean).

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
/// Displays images. Supports animated images and video playback.
@MainActor
public struct Image: NSViewRepresentable {
    let imageContainer: ImageContainer
    let onCreated: ((ImageView) -> Void)?
    @Binding var isVideoLooping: Bool
    var onVideoFinished: (() -> Void)?
    var restartVideo: Bool = false

    public init(_ image: NSImage) {
        self.init(ImageContainer(image: image))
    }

    public init(_ imageContainer: ImageContainer,
                isVideoLooping: Binding<Bool> = .constant(true),
                onCreated: ((ImageView) -> Void)? = nil) {
        self.imageContainer = imageContainer
        self._isVideoLooping = isVideoLooping
        self.onCreated = onCreated
    }

    public func makeNSView(context: Context) -> ImageView {
        let view = ImageView()
        if view.isVideoLooping != isVideoLooping {
            view.isVideoLooping = isVideoLooping
        }
        view.onVideoFinished = onVideoFinished
        onCreated?(view)
        return view
    }

    public func updateNSView(_ imageView: ImageView, context: Context) {
        if imageView.isVideoLooping != isVideoLooping {
            imageView.isVideoLooping = isVideoLooping
        }
        if restartVideo {
            imageView.restartVideo()
        }
        guard imageView.imageContainer?.image !== imageContainer.image else { return }
        imageView.imageContainer = imageContainer
    }
}
#elseif os(iOS) || os(tvOS)
/// Displays images. Supports animated images and video playback.
@MainActor
public struct Image: UIViewRepresentable {
    let imageContainer: ImageContainer
    let onCreated: ((ImageView) -> Void)?
    var resizingMode: ImageResizingMode?
    @Binding var isVideoLooping: Bool
    var onVideoFinished: (() -> Void)?
    var restartVideo: Bool = false

    public init(_ image: UIImage) {
        self.init(ImageContainer(image: image))
    }

    public init(_ imageContainer: ImageContainer,
                isVideoLooping: Binding<Bool> = .constant(true),
                onCreated: ((ImageView) -> Void)? = nil) {
        self.imageContainer = imageContainer
        self._isVideoLooping = isVideoLooping
        self.onCreated = onCreated
    }

    public func makeUIView(context: Context) -> ImageView {
        let imageView = ImageView()
        if let resizingMode = self.resizingMode {
            imageView.resizingMode = resizingMode
        }
        imageView.videoPlayerView.isLooping = isVideoLooping
        imageView.videoPlayerView.onVideoFinished = onVideoFinished
        onCreated?(imageView)
        return imageView
    }

    public func updateUIView(_ imageView: ImageView, context: Context) {
        imageView.videoPlayerView.isLooping = isVideoLooping
        if restartVideo {
            imageView.videoPlayerView.restart()
        }
        guard imageView.imageContainer?.image !== imageContainer.image else { return }
        imageView.imageContainer = imageContainer
    }

    /// Sets the resizing mode for the image.
    public func resizingMode(_ mode: ImageResizingMode) -> Self {
        var copy = self
        copy.resizingMode = mode
        return copy
    }
}
#endif

extension Image {
    public func onVideoFinished(content: @escaping () -> Void) -> Self {
        var copy = self
        copy.onVideoFinished = content
        return copy
    }

    public func restartVideo(_ value: Bool) -> Self {
        var copy = self
        copy.restartVideo = value
        return copy
    }
}
