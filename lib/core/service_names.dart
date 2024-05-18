enum ServiceName {
  openai('openai'),
  groq('groq'),
  dyrektywa('dyrektywa'),
  perplexity('perplexity'),
  gemini('gemini');

  final String name;
  const ServiceName(this.name);
}
