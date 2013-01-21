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