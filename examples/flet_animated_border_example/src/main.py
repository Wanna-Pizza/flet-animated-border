import flet as ft

from flet_animated_border import FletAnimatedBorder,FletBorderType

def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER
    
    border_anim = FletAnimatedBorder(
        borderRadius=10,
        borderWidth=5,
        glowOpacity=0.6,
        border_type=FletBorderType.DUAL,
        firstDualColor=ft.Colors.WHITE,
        secondDualColor=ft.Colors.YELLOW,
        gradient_colors=[
            ft.Colors.RED,
            ft.Colors.YELLOW,
            ft.Colors.GREEN,
            ft.Colors.BLUE,

        ],
        smooth_gradient_loop=True,
        
        animate=ft.Animation(1000, ft.AnimationCurve.EASE_IN_OUT),
    )
    
    button = ft.ElevatedButton("123 граница", width=200, height=50)
    border_anim.content = button
    
    page.add(ft.Container(
        border_anim,
        expand=True,
        alignment=ft.alignment.center,
        bgcolor='black,0.5'))
    
    def on_width_change(e):
        border_anim.borderWidth = e.control.value
        border_anim.update()
        
    def on_radius_change(e):
        border_anim.borderRadius = e.control.value
        border_anim.update()
        
    def on_glow_change(e):
        border_anim.glowOpacity = e.control.value
        border_anim.update()
    
    def switch_to_soft_gradient(e):
        border_anim.border_type = FletBorderType.SOFT_GRADIENT
        border_anim.update()
    
    def switch_to_dual_gradient(e):
        border_anim.border_type = FletBorderType.DUAL
        border_anim.update()


    page.add(
        ft.Container(
            ft.Row([ft.Column([
                ft.Text("Width:"),
                ft.Slider(
                    min=0,
                    max=20,
                    divisions=2,
                    value=5,
                    on_change=on_width_change,
                ),
                ft.Text("Radius:"),
                ft.Slider(
                    min=0,
                    max=50,
                    divisions=2,
                    value=10,
                    on_change=on_radius_change,
                ),
                ft.Text("Glow Intensity:"),
                ft.Slider(
                    min=0,
                    max=1,
                    divisions=2,
                    value=0.6,
                    on_change=on_glow_change,
                ),
            ]),
            ft.Column([
                ft.ElevatedButton("Switch to Soft Gradient", on_click=switch_to_soft_gradient),
                ft.ElevatedButton("Switch to Dual", on_click=switch_to_dual_gradient),
            ])
            
            
            ]),
            width=500,
            padding=20,
            bgcolor="white10",
            border_radius=10,
        )
    )


ft.app(main)
