//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration LcdMenuC
{
    provides interface LcdMenu;
}

implementation
{
    components LcdMenuP as App;
    LcdMenu = App;

	components LcdControlC;
    App.LcdControl -> LcdControlC;
}