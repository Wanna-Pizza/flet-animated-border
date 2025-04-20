# Introduction

FletAnimatedBorder for Flet.

## Examples

```
import flet as ft

from flet_animated_border import FletAnimatedBorder


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    page.add(

                ft.Container(height=150, width=300, alignment = ft.alignment.center, bgcolor=ft.Colors.PURPLE_200, content=FletAnimatedBorder(
                    tooltip="My new FletAnimatedBorder Control tooltip",
                    value = "My new FletAnimatedBorder Flet Control", 
                ),),

    )


ft.app(main)
```

## Classes

[FletAnimatedBorder](FletAnimatedBorder.md)


