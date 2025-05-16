import streamlit as st
import time
from create_website_copy_request import get_response

st.set_page_config(
    page_title="Contoso Website Generator",
    page_icon="✏️",
    layout="wide"
)

st.markdown("""
<style>
    .main-header {color: #1E88E5; font-size: 2.5rem}
    .subheader {color: #424242; font-size: 1.5rem}
    .generated-content {background-color: #f0f2f6; padding: 20px; border-radius: 10px; border-left: 5px solid #1E88E5}
    .context-box {font-size: 0.9rem; background-color: #f9f9f9; border-radius: 5px; padding: 15px}
</style>
""", unsafe_allow_html=True)

st.markdown("<h1 class='main-header'>Contoso Website Generator</h1>", unsafe_allow_html=True)
st.markdown("This is a platform that generates professional website copy based on your specifications using AI.")


with st.sidebar:
    st.markdown("### How to Use")
    st.markdown("""
    1. Enter a description of the website copy you need to generate
    2. Choose your preferred tone and length
    3. Click 'Generate Copy' and wait for results
    """)
    
    st.markdown("Get Examples from here..")
    examples = [
        "Create the website copy for the tents catalog page",
        "Write an 'About Us' page for an eco-friendly clothing brand",
        "Generate a product description for a premium coffee machine"
    ]
    
    selected_example = st.selectbox("Try an example:", ["Select an example..."] + examples)
    if selected_example != "Select an example...":
        st.session_state.question = selected_example


if 'question' not in st.session_state:
    st.session_state.question = ""


st.markdown("<h2 class='subheader'>Let's get your specifications...</h2>", unsafe_allow_html=True)
question = st.text_area(
    "Be specific about your needs and give context:",
    value=st.session_state.question,
    height=100,
    placeholder="E.g., Create engaging website copy for our tents catalog page, highlighting durability and outdoor adventure"
)


st.session_state.question = question


col1, col2 = st.columns(2)
with col1:
    tone = st.selectbox(
        "Tone of voice:",
        ["Professional", "Friendly", "Enthusiastic", "Informative", "Persuasive"]
    )
with col2:
    length = st.select_slider(
        "Content length:",
        options=["Brief", "Moderate", "Detailed"]
    )

if st.button("Generate Website Copy", type="primary", disabled=not question.strip()):
    if question.strip():
        with st.spinner('Crafting your website copy...'):
            enhanced_question = f"{question} Use a {tone.lower()} tone and provide {length.lower()} content."
            
            result = get_response(enhanced_question)
            
        st.success("✅ Website copy generated successfully!")
        
        tab1, tab2 = st.tabs(["Generated Copy", "Context Used"])
        
        with tab1:
            st.markdown("<div class='generated-content'>", unsafe_allow_html=True)
            st.markdown(result["answer"])
            st.markdown("</div>", unsafe_allow_html=True)
            
            
            col1, col2 = st.columns(2)
            with col1:
                st.download_button(
                    "Download as Text",
                    result["answer"],
                    file_name="website_copy.txt",
                    mime="text/plain"
                )
            with col2:
                st.button("Copy to Clipboard", on_click=lambda: st.code(result["answer"]))
        
        with tab2:
            st.markdown("<div class='context-box'>", unsafe_allow_html=True)
            st.markdown("### Context Used For Generation")
            st.markdown(result["context"])
            st.markdown("</div>", unsafe_allow_html=True)
    else:
        st.warning("Please enter a description of the website copy you need.")