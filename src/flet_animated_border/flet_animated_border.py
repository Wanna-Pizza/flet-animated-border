from enum import Enum
from typing import Any, Optional, List, Union

from flet.core.constrained_control import ConstrainedControl
from flet.core.control import Control, OptionalNumber
from flet.core.animation import AnimationValue
from flet.core.gradients import Gradient

from flet.core.types import (
    ColorEnums,
    ColorValue,
)
class BorderType(Enum):
    DUAL = "dual"
    SOFT_GRADIENT = "soft_gradient"


class AnimatedBorder(ConstrainedControl):
    """
    AnimatedBorder Control description.
    """

    def __init__(
        self,
        #
        # Control
        #
        content: Optional[Control] = None,
        opacity: OptionalNumber = None,
        tooltip: Optional[str] = None,
        visible: Optional[bool] = None,
        data: Any = None,
        #
        # ConstrainedControl
        #
        left: OptionalNumber = None,
        top: OptionalNumber = None,
        right: OptionalNumber = None,
        bottom: OptionalNumber = None,
        #
        # FletAnimatedBorder specific
        #
        borderWidth: Optional[float] = 5.0,
        borderRadius: Optional[float] = 5.0,
        glowOpacity: Optional[float] = 0.0,
        firstDualColor: Optional[str] = "yellow",
        secondDualColor: Optional[str] = "orange",
        trackDualColor: Optional[str] = "transparent",
        border_type: Optional[BorderType] = BorderType.DUAL,
        gradient_colors: Optional[List[str]] = None,
        smooth_gradient_loop: Optional[bool] = True,
        duration_seconds: Optional[int] = 3,
        animate: Optional[AnimationValue] = None,
        on_animation_end: Optional[callable] = None,
    ):
        ConstrainedControl.__init__(
            self,
            tooltip=tooltip,
            opacity=opacity,
            visible=visible,
            data=data,
            left=left,
            top=top,
            right=right,
            bottom=bottom,
        )

        self._border_width = None
        self._border_radius = None
        self._glow_opacity = None
        self._duration_seconds = None
        self._animate = None
        self._on_animation_end = None
        self._first_dual_color = None
        self._second_dual_color = None
        self._track_dual_color = None
        self._border_type = None
        self._gradient = None
        self._gradient_colors = None
        self._smooth_gradient_loop = None
        
        self.__content = None
        
        self.content = content
        self.borderWidth = borderWidth
        self.borderRadius = borderRadius
        self.glowOpacity = glowOpacity
        self.firstDualColor = firstDualColor
        self.secondDualColor = secondDualColor
        self.trackDualColor = trackDualColor
        self.border_type = border_type
        self.gradient_colors = gradient_colors
        self.smooth_gradient_loop = smooth_gradient_loop
        self.duration_seconds = duration_seconds
        self.animate = animate
        self.on_animation_end = on_animation_end

    def _get_control_name(self):
        return "flet_animated_border"

    def before_update(self):
        super().before_update()
        self._set_attr_json("borderWidth", self._border_width)
        self._set_attr_json("borderRadius", self._border_radius)
        self._set_attr_json("glowOpacity", self._glow_opacity)
        self._set_attr_json("duration_seconds", self._duration_seconds)
        self._set_attr_json("animate", self._animate)
        self._set_attr("onAnimationEnd", True if self._on_animation_end is not None else None)
        self._set_attr("borderType", self._border_type.value if self._border_type else None)
        self._set_attr("smoothGradientLoop", self._smooth_gradient_loop)
        
        # Extract colors for ZoAnimatedGradientBorder
        gradient_colors_list = self._gradient_colors or []
        
        # If a gradient is provided but no explicit gradient_colors, extract colors from gradient
        if not gradient_colors_list and self._gradient and hasattr(self._gradient, "colors"):
            gradient_colors_list = self._gradient.colors
            
        # Send gradient colors to Dart implementation
        self._set_attr_json("gradientColors", gradient_colors_list)
    
    def _get_children(self):
        children = []
        if self.__content is not None:
            self.__content._set_attr_internal("n", "content")
            children.append(self.__content)
        return children

    # content
    @property
    def content(self) -> Optional[Control]:
        return self.__content

    @content.setter
    def content(self, value: Optional[Control]):
        self.__content = value

    # borderWidth
    @property
    def borderWidth(self):
        return self._border_width
    
    @borderWidth.setter
    def borderWidth(self, value):
        print(f"Setting borderWidth to {value}")
        self._border_width = value
    
    # borderRadius
    @property
    def borderRadius(self):
        return self._border_radius
    
    @borderRadius.setter
    def borderRadius(self, value):
        print(f"Setting borderRadius to {value}")
        self._border_radius = value
    
    # glowOpacity
    @property
    def glowOpacity(self):
        return self._glow_opacity

    @glowOpacity.setter
    def glowOpacity(self, value):
        print(f"Setting glowOpacity to {value}")
        self._glow_opacity = value
        
    # duration_seconds
    @property
    def duration_seconds(self):
        return self._duration_seconds

    @duration_seconds.setter
    def duration_seconds(self, value):
        print(f"Setting duration_seconds to {value}")
        self._duration_seconds = value
        
    # animate
    @property
    def animate(self) -> Optional[AnimationValue]:
        return self._animate

    @animate.setter
    def animate(self, value: Optional[AnimationValue]):
        print(f"Setting animate to {value}")
        self._animate = value
        
    # on_animation_end
    @property
    def on_animation_end(self):
        return self._on_animation_end

    @on_animation_end.setter
    def on_animation_end(self, handler):
        self._on_animation_end = handler
        self._add_event_handler("animation_end", handler)
        
    # firstDualColor
    @property
    def firstDualColor(self):
        return self._first_dual_color
    
    @firstDualColor.setter
    def firstDualColor(self, value: Optional[ColorValue]):
        self._first_dual_color = value
        self._set_enum_attr("firstDualColor", value, ColorEnums)
        
    # secondDualColor
    @property
    def secondDualColor(self):
        return self._second_dual_color
    
    @secondDualColor.setter
    def secondDualColor(self, value: Optional[ColorValue]):
        self._second_dual_color = value
        self._set_enum_attr("secondDualColor", value, ColorEnums)
        
    # trackDualColor
    @property
    def trackDualColor(self):
        return self._track_dual_color
    
    @trackDualColor.setter
    def trackDualColor(self, value: Optional[ColorValue]):
        self._track_dual_color = value
        self._set_enum_attr("trackDualColor", value, ColorEnums)
        
    # border_type
    @property
    def border_type(self) -> Optional[BorderType]:
        return self._border_type
    
    @border_type.setter
    def border_type(self, value: Optional[BorderType]):
        print(f"Setting border_type to {value}")
        self._border_type = value
        
    # gradient_colors
    @property
    def gradient_colors(self) -> Optional[List[str]]:
        return self._gradient_colors
    
    @gradient_colors.setter
    def gradient_colors(self, value: Optional[List[str]]):
        print(f"Setting gradient_colors to {value}")
        self._gradient_colors = value
        
    # smooth_gradient_loop
    @property
    def smooth_gradient_loop(self) -> Optional[bool]:
        return self._smooth_gradient_loop
    
    @smooth_gradient_loop.setter
    def smooth_gradient_loop(self, value: Optional[bool]):
        print(f"Setting smooth_gradient_loop to {value}")
        self._smooth_gradient_loop = value
